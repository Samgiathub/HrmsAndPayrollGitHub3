using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0130EmpMobileStockSales1
{
    public decimal StockTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal MobileCatId { get; set; }

    public decimal EmpId { get; set; }

    public decimal StoreId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? MobileCatSale { get; set; }

    public decimal? MobileCatStock { get; set; }

    public decimal? MobileRemarkId { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? LoginId { get; set; }

    public decimal? ParentId { get; set; }
}
