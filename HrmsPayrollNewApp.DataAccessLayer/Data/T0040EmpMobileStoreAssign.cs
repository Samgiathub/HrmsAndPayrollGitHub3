using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040EmpMobileStoreAssign
{
    public decimal StoreTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpCode { get; set; }

    public decimal StoreId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? LoginId { get; set; }

    public string? OldEmpCode { get; set; }

    public string? CurrentOutletMapping { get; set; }

    public string? StoreCode { get; set; }

    public string? DealerCode { get; set; }
}
