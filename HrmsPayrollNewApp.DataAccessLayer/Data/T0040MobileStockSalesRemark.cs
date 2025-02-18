using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040MobileStockSalesRemark
{
    public decimal MobileRemarkId { get; set; }

    public decimal CmpId { get; set; }

    public string? RemarkName { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? LoginId { get; set; }
}
