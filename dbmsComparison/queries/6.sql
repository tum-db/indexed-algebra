select 1 from
test tbl1, test tbl2, test tbl3, test tbl4, test tbl5, test tbl6
where tbl1.x=tbl2.y and tbl2.x=tbl3.y and tbl3.x=tbl4.y and tbl4.x=tbl5.y and tbl5.x=tbl6.y;
