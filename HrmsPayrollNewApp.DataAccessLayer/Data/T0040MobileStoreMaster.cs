using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040MobileStoreMaster
{
    public decimal StoreId { get; set; }

    public decimal CmpId { get; set; }

    public string? StoreCode { get; set; }

    public string? StoreName { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? LoginId { get; set; }
}
