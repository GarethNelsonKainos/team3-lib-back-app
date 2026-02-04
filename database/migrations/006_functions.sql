-- Migration 006: Database Functions
-- Utility functions for borrowing operations and statistics

-- ============================================
-- FUNCTION: Check Borrowing Eligibility
-- Returns eligibility status and reason for a member
-- ============================================
CREATE OR REPLACE FUNCTION check_borrowing_eligibility(p_member_id BIGINT)
RETURNS TABLE (
    is_eligible BOOLEAN,
    current_borrows INTEGER,
    max_borrows INTEGER,
    has_overdue BOOLEAN,
    overdue_count INTEGER,
    reason TEXT
) AS $$
DECLARE
    v_current_borrows INTEGER;
    v_overdue_count INTEGER;
    v_member_exists BOOLEAN;
BEGIN
    -- Check if member exists
    SELECT EXISTS(SELECT 1 FROM members WHERE id = p_member_id) INTO v_member_exists;
    
    IF NOT v_member_exists THEN
        RETURN QUERY SELECT 
            FALSE::BOOLEAN,
            0::INTEGER,
            3::INTEGER,
            FALSE::BOOLEAN,
            0::INTEGER,
            'Member not found'::TEXT;
        RETURN;
    END IF;
    
    -- Count current borrows
    SELECT COUNT(*) INTO v_current_borrows
    FROM borrowing_records
    WHERE member_id = p_member_id AND returned_date IS NULL;
    
    -- Count overdue items
    SELECT COUNT(*) INTO v_overdue_count
    FROM borrowing_records
    WHERE member_id = p_member_id 
      AND returned_date IS NULL 
      AND due_date < CURRENT_DATE;
    
    -- Determine eligibility
    IF v_overdue_count > 0 THEN
        RETURN QUERY SELECT 
            FALSE::BOOLEAN,
            v_current_borrows,
            3::INTEGER,
            TRUE::BOOLEAN,
            v_overdue_count,
            format('Member has %s overdue item(s). Must return overdue books before borrowing.', v_overdue_count)::TEXT;
    ELSIF v_current_borrows >= 3 THEN
        RETURN QUERY SELECT 
            FALSE::BOOLEAN,
            v_current_borrows,
            3::INTEGER,
            FALSE::BOOLEAN,
            0::INTEGER,
            'Member has reached maximum borrowing limit of 3 books.'::TEXT;
    ELSE
        RETURN QUERY SELECT 
            TRUE::BOOLEAN,
            v_current_borrows,
            3::INTEGER,
            FALSE::BOOLEAN,
            0::INTEGER,
            format('Eligible to borrow %s more book(s).', 3 - v_current_borrows)::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCTION: Update Overdue Status
-- Updates status to 'OVERDUE' for past-due borrows
-- Returns count of records updated
-- ============================================
CREATE OR REPLACE FUNCTION update_overdue_status()
RETURNS TABLE (
    records_updated INTEGER,
    execution_time TIMESTAMP WITH TIME ZONE
) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    UPDATE borrowing_records
    SET status = 'OVERDUE',
        updated_at = NOW()
    WHERE returned_date IS NULL
      AND due_date < CURRENT_DATE
      AND status != 'OVERDUE';
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    
    RETURN QUERY SELECT v_count, NOW();
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCTION: Get Borrowing Statistics
-- Returns borrowing statistics for a date range
-- ============================================
CREATE OR REPLACE FUNCTION get_borrowing_statistics(
    p_start_date DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
    p_end_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    period_start DATE,
    period_end DATE,
    total_borrows BIGINT,
    total_returns BIGINT,
    unique_members BIGINT,
    unique_books BIGINT,
    avg_loan_duration NUMERIC,
    overdue_at_return BIGINT,
    most_borrowed_book VARCHAR(255),
    most_active_member VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    WITH borrow_stats AS (
        SELECT 
            COUNT(*) AS borrows,
            COUNT(*) FILTER (WHERE returned_date BETWEEN p_start_date AND p_end_date) AS returns,
            COUNT(DISTINCT br.member_id) AS members,
            COUNT(DISTINCT bc.book_id) AS books,
            AVG(
                CASE 
                    WHEN returned_date IS NOT NULL 
                    THEN returned_date - borrowed_date 
                END
            ) AS avg_duration,
            COUNT(*) FILTER (
                WHERE returned_date IS NOT NULL 
                AND returned_date > due_date
            ) AS late_returns
        FROM borrowing_records br
        JOIN book_copies bc ON br.book_copy_id = bc.id
        WHERE br.borrowed_date BETWEEN p_start_date AND p_end_date
    ),
    top_book AS (
        SELECT b.title
        FROM borrowing_records br
        JOIN book_copies bc ON br.book_copy_id = bc.id
        JOIN books b ON bc.book_id = b.id
        WHERE br.borrowed_date BETWEEN p_start_date AND p_end_date
        GROUP BY b.id, b.title
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ),
    top_member AS (
        SELECT m.first_name || ' ' || m.last_name AS name
        FROM borrowing_records br
        JOIN members m ON br.member_id = m.id
        WHERE br.borrowed_date BETWEEN p_start_date AND p_end_date
        GROUP BY m.id, m.first_name, m.last_name
        ORDER BY COUNT(*) DESC
        LIMIT 1
    )
    SELECT 
        p_start_date,
        p_end_date,
        bs.borrows,
        bs.returns,
        bs.members,
        bs.books,
        ROUND(COALESCE(bs.avg_duration, 0), 1),
        bs.late_returns,
        COALESCE(tb.title, 'N/A'),
        COALESCE(tm.name, 'N/A')
    FROM borrow_stats bs
    CROSS JOIN (SELECT title FROM top_book UNION ALL SELECT NULL LIMIT 1) tb
    CROSS JOIN (SELECT name FROM top_member UNION ALL SELECT NULL LIMIT 1) tm;
END;
$$ LANGUAGE plpgsql;