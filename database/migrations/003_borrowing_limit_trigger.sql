-- Migration 003: Borrowing Limit Trigger
-- Enforces maximum 3 books per member and blocks borrowing with overdue items

CREATE OR REPLACE FUNCTION check_member_borrow_limit()
RETURNS TRIGGER AS $$
DECLARE
    current_borrows INTEGER;
    has_overdue BOOLEAN;
BEGIN
    -- Only check on new borrows (INSERT) or when changing to active borrow (UPDATE setting returned_date to NULL)
    IF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND NEW.returned_date IS NULL AND OLD.returned_date IS NOT NULL) THEN
        
        -- Count current active borrows for this member (excluding the current record on UPDATE)
        SELECT COUNT(*) INTO current_borrows
        FROM borrowing_records
        WHERE member_id = NEW.member_id
          AND returned_date IS NULL
          AND (TG_OP = 'INSERT' OR id != NEW.id);
        
        -- Check if member already has 3 or more books
        IF current_borrows >= 3 THEN
            RAISE EXCEPTION 'Member has reached the maximum borrowing limit of 3 books'
                USING ERRCODE = 'P0001',
                      HINT = 'The member must return a book before borrowing another one.';
        END IF;
        
        -- Check if member has any overdue items
        SELECT EXISTS (
            SELECT 1
            FROM borrowing_records
            WHERE member_id = NEW.member_id
              AND returned_date IS NULL
              AND due_date < CURRENT_DATE
              AND (TG_OP = 'INSERT' OR id != NEW.id)
        ) INTO has_overdue;
        
        IF has_overdue THEN
            RAISE EXCEPTION 'Member has overdue items and cannot borrow new books'
                USING ERRCODE = 'P0002',
                      HINT = 'The member must return all overdue books before borrowing new ones.';
        END IF;
        
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists and recreate
DROP TRIGGER IF EXISTS trg_check_member_borrow_limit ON borrowing_records;

CREATE TRIGGER trg_check_member_borrow_limit
    BEFORE INSERT OR UPDATE ON borrowing_records
    FOR EACH ROW
    EXECUTE FUNCTION check_member_borrow_limit();
