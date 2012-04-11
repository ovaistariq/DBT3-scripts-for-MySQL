# pre-cache data
select sum(l_quantity) from lineitem;
select sum(o_totalprice) from orders;
select sum(ps_supplycost) from partsupp;
select sum(p_retailprice) from part;
select sum(c_acctbal) from customer;
select sum(s_acctbal) from supplier;
select * from region;
select * from nation;
