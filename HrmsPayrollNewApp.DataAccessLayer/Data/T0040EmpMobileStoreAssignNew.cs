using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040EmpMobileStoreAssignNew
{
    public decimal StoreTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpCode { get; set; }

    public decimal StoreId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? LoginId { get; set; }
}
