<h1>RFM analysis with SQL and Tableau visualizations</h1>

The project is to perform Recency-Frequency-Monetary analysis using SQL on unknown company's data that sold different vehicles (from cars to trains) from the period of January 2003 to May 2005. Data was downloaded from <a href='https://github.com/AllThingsDataWithAngelina/DataSource'>here</a>. The sales data was analyzed to find best revenue year and months, best selling products and company's biggest markets by revenue. Also RFM analysis was performed to segment customers into 6 different groups: <b><i>'new_customers'</i></b> - those who made their first purchase recently, <b><i>'lost_customers'</i></b> - who didn't make frequent purchases and last on was long time ago, <b><i>'potential_churners'</i></b> - customers, who's last purchase was long time ago but they used to buy frequently in the past, <b><i>'cannot_lose'</i></b> - big and frequent buyers who didn't make any purchases recently, <b><i>'active_customers'</i></b> - a group that often makes small purchases and <b><i>'loyal_customers'</i></b> - big and frequent buyers. The results of the analysis were visualized with Tableau Public and published in <a href='https://public.tableau.com/app/profile/ruslan.khurazov'>my account</a>.
<div class="row">
  <div class="column">
    <a href='https://public.tableau.com/app/profile/ruslan.khurazov/viz/SalesDashboard1_16550891440780/SalesDashboard'><img src="https://github.com/KhurazovRuslan/sales_analysis_sql_tableau/blob/main/SalesDashboard.png" alt="SalesDashboard1" style="width:90%"></a>
  </div>
  <div class="column">
    <a href='https://public.tableau.com/app/profile/ruslan.khurazov/viz/SalesDashboard2_16550893421380/SalesDashboard2'><img src="https://github.com/KhurazovRuslan/sales_analysis_sql_tableau/blob/main/SalesDashboard2.png" alt="SalesDashboard2" style="width:90%"></a>
  </div>
</div>
<h2>Software used in the project:</h2>
<li>Microsoft SQL Server Management Studio v.18.11.1</li>
<li>Tableau Public 2022.1</li>
<h2>Files:</h2>
<li><a href='https://github.com/KhurazovRuslan/sales_analysis_sql_tableau/blob/main/sales_analysis.sql'>sales_analysis.sql</a> - .sql file that contains script for Microsoft SQL Server Management to perform revenue and RFM analysis using different statements, window functions, CTEs and temp tables</li>
<p>
  
  
The dashboards and SQL queries show the best selling products, biggest markets for the company, different groups of clients that need some additional attention and encoragement to make purchases again or buy bigger as well as pairs of products that could be promoted together to increase the revenue.
