# =============================================================================
# Python Analysis
# =============================================================================

import pandas as pd

df_product = pd.read_csv("prod_level.csv")

df_rev_clean = pd.read_csv("order_rev_clean.csv")

df_order = pd.read_csv("order_level.csv")

df_customer = pd.read_csv("customer_level.csv")


# =============================================================================
# Product Analysis - Pareto
# =============================================================================


#Aggregating revenue per product
prod_rev = (
    df_product
    .groupby("product_id", as_index=False)["revenue"]
    .sum()
    .sort_values(by="revenue", ascending=False)
)


#cumulative share:
prod_rev["cum_revenue"] = prod_rev["revenue"].cumsum()
total_rev = prod_rev["revenue"].sum()

prod_rev["cum_pct"] = prod_rev["cum_revenue"] / total_rev


#80% threshold of the products:
pareto_80 = prod_rev[prod_rev["cum_pct"] <= 0.8]


# metrics:
#number of products in table pareto_80: 9052 products
num_products_80 = pareto_80.shape[0]
#total product number at prod_rev table: 32216 products
total_products = prod_rev.shape[0]


# when we ratio them: 0.28 of prod at 80% threshold
share_products = num_products_80 / total_products

print(share_products)
#0.2809783958281599


#####################################
#Top 28% of products generate ~80% of revenue.
#A relatively small share of products contributes the majority of total revenue, indicating strong revenue concentration.
#########################################


#graph:
prod_rev["product_rank"] = range(1, len(prod_rev) + 1)
prod_rev["product_pct"] = prod_rev["product_rank"] / len(prod_rev)


import matplotlib.pyplot as plt

plt.plot(prod_rev["product_pct"], prod_rev["cum_pct"])

plt.axhline(y=0.8)   # 80% revenue
plt.axvline(x=0.28)  # 0.28

plt.xlabel("Share of Products")
plt.ylabel("Cumulative Revenue Share")
plt.title("Pareto Analysis (Products)")

plt.savefig("product_pareto.png", dpi=300, bbox_inches="tight")
plt.show()


# =============================================================================
# Customer Analysis - Pareto
# =============================================================================


# Sorting customers by spending:
cust_rev = (
    df_customer
    .sort_values(by="total_spent", ascending=False)
    .reset_index(drop=True)
)


# cumulative revenue share:
cust_rev["cum_revenue"] = cust_rev["total_spent"].cumsum()
total_rev = cust_rev["total_spent"].sum()

cust_rev["cum_pct"] = cust_rev["cum_revenue"] / total_rev


# customer share 
cust_rev["customer_rank"] = range(1, len(cust_rev) + 1)
cust_rev["customer_pct"] = cust_rev["customer_rank"] / len(cust_rev)


#metric
pareto_80_cust = cust_rev[cust_rev["cum_pct"] <= 0.8]

share_customers = pareto_80_cust.shape[0] / cust_rev.shape[0]

print(share_customers)
# 0.48848518605797037


#graph:
import matplotlib.pyplot as plt

plt.plot(cust_rev["customer_pct"], cust_rev["cum_pct"])

plt.axhline(y=0.8)
plt.axvline(x=share_customers)

plt.xlabel("Share of Customers")
plt.ylabel("Cumulative Revenue Share")
plt.title("Pareto Analysis (Customers)")

plt.savefig("customer_pareto.png", dpi=300, bbox_inches="tight")
plt.show()


#########################################
# 48% of customers making 80% of revenue
# not concentrated, broad distribution
###############################################


# =============================================================================
# Customer Spending Distribution
# =============================================================================


import matplotlib.pyplot as plt

plt.hist(df_customer["total_spent"], bins=50)

plt.xlabel("Customer Spend")
plt.ylabel("Frequency")
plt.title("Customer Spend Distribution")

plt.savefig("customer_distrb.png", dpi=300, bbox_inches="tight")
plt.show()


# Most customers spend low amounts, a few spend a lot


# Scaling to visualize the patterns better:
import numpy as np

plt.hist(np.log1p(df_customer["total_spent"]), bins=50)

plt.xlabel("Log(Customer Spend)")
plt.ylabel("Frequency")
plt.title("Customer Spend Distribution (Log Scale)")

plt.savefig("customer_distrb_log.png", dpi=300, bbox_inches="tight")
plt.show()


#How spending is distributed without extreme outliers distorting the view


df_customer["total_spent"].describe()
##
#count    93358.000000
#mean       165.168210
#std        226.292101
#min          9.590000
#25%         63.010000
#50%        107.780000
#75%        182.510000
#max      13664.080000
##
df_customer["total_spent"].median()
#107.78
#mean > median 


####################################
#Customer spending is right-skewed, with a long tail of higher-spending customers. Most customers spend low amounts, while a small number of customers contribute disproportionately high values. 
#However, revenue is not highly concentrated, as a relatively large share of customers contributes to total revenue.
##########################################


# =============================================================================
# Order Value Distribution
# =============================================================================


import matplotlib.pyplot as plt

plt.hist(df_order["total_revenue"], bins=50)

plt.xlabel("Order Value")
plt.ylabel("Number of Orders")
plt.title("Order Value Distribution")

plt.savefig("order_distrb.png", dpi=300, bbox_inches="tight")
plt.show()


#scaling to visualize the patterns better:
import numpy as np

plt.hist(np.log1p(df_order["total_revenue"]), bins=50)

plt.xlabel("Log(Order Value)")
plt.ylabel("Number of Orders")
plt.title("Order Value Distribution (Log Scale)")

plt.savefig("order_distrb_log.png", dpi=300, bbox_inches="tight")
plt.show()


df_order["total_revenue"].describe()
##
#count    96478.000000
#mean       159.826839
#std        218.794219
#min          9.590000
#25%         61.850000
#50%        105.280000
#75%        176.260000
#max      13664.080000
##
df_order["total_revenue"].median()
#105.28


###########################
#Order values are right-skewed, with most transactions concentrated at lower values and a small number of high-value orders forming a long tail.
#Customer-level behavior is almost identical to order-level behavior.(Since most customers place only one order)

#The business operates primarily on single-purchase customers, with limited repeat behavior, making each transaction largely independent.

#low retention
##################################


# =============================================================================
# Item-Revenue relationship
# =============================================================================


agg = (
    df_order
    .groupby("items_per_order", as_index=False)
    .agg(
        avg_revenue=("total_revenue", "mean"),
        count=("order_id", "count")
    )
)


import matplotlib.pyplot as plt

plt.plot(agg["items_per_order"], agg["avg_revenue"], marker="o")

plt.xlabel("Items per Order")
plt.ylabel("Average Revenue")
plt.title("Average Revenue vs Items per Order")

plt.savefig("item_rev_avg.png", dpi=300, bbox_inches="tight")
plt.show()



print(agg)
######
#    items_per_order  avg_revenue  count
#0                 1   150.029252  86843
#1                 2   210.933144   7392
#2                 3   292.262557   1306
#3                 4   391.719232    495
#4                 5   462.227979    193
#5                 6   530.074241    191
#6                 7   611.453636     22
#7                 8  2304.925000      8
#8                 9  1092.240000      3
#9                10  1687.460000      8
#10               11  1107.880000      4
#11               12   743.490000      5
#12               13   485.940000      1
#13               14   771.400000      2
#14               15  1004.325000      2
#15               20  2232.600000      2
#16               21   196.170000      1 
######

#######
#Average revenue increases with the number of items per order, but the relationship becomes unstable for larger orders due to low sample sizes.
#Most orders = 1 item. Multi-item orders: higher revenue per order, but rare
#While larger orders generate higher revenue per transaction, most revenue is driven by single-item orders due to their high frequency.
########



#Filter out noisy groups:


agg_filtered = agg[agg["count"] > 100]

plt.plot(agg_filtered["items_per_order"], agg_filtered["avg_revenue"], marker="o")
plt.xlabel("Items per Order")
plt.ylabel("Average Revenue")
plt.title("Avg Revenue vs Items (Filtered)")

plt.savefig("item_rev_avg_cut.png", dpi=300, bbox_inches="tight")
plt.show()

######
#Results are restricted to item counts with sufficient observations.

#agg plot: 
#The full distribution shows highly volatile average revenue for larger orders, driven by very low sample sizes rather than meaningful patterns.
#After cutting:
#When restricting to item counts with sufficient observations, average revenue increases steadily with the number of items per order.
######


# =============================================================================
# Revenue decomposition
# =============================================================================


df_order["order_date"] = pd.to_datetime(df_order["order_date"])
df_order["order_month"] = df_order["order_date"].dt.to_period("M").dt.to_timestamp()


monthly = df_order.groupby("order_month").agg(
    revenue=("total_revenue", "sum"),
    orders=("order_id", "nunique")
).reset_index()


monthly["aov"] = monthly["revenue"] / monthly["orders"]


#Is the business growing?
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick

plt.plot(monthly["order_month"], monthly["revenue"])

plt.xticks(rotation=45, ha="right")

plt.gca().yaxis.set_major_formatter(mtick.StrMethodFormatter('{x:,.0f}'))

plt.title("Monthly Revenue")
plt.show()


#Is growth driven by volume?
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick

plt.plot(monthly["order_month"], monthly["orders"])

plt.xticks(rotation=45, ha="right")

plt.gca().yaxis.set_major_formatter(mtick.StrMethodFormatter('{x:,.0f}'))

plt.title("Order Volume")
plt.show()


#Are people spending more per order?
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
plt.plot(monthly["order_month"], monthly["aov"])

plt.xticks(rotation=45, ha="right")

plt.gca().yaxis.set_major_formatter(mtick.StrMethodFormatter('{x:,.0f}'))

plt.title("Average Order Value (AOV)")
plt.show()


###########
#Revenue increases over time
#AOV is stable
#Orders increase
#Revenue growth is primarily driven by order volume rather than increases in average order value.
########
