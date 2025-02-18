using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040MobileStoreEmployee
{
    public decimal StoreTranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal StoreId { get; set; }

    public string? StoreName { get; set; }

    public DateTime EffectiveDate { get; set; }
}
