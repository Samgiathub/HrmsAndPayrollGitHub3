using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040AdSlabSetting
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AdId { get; set; }

    public decimal FromSlab { get; set; }

    public decimal ToSlab { get; set; }

    public string? CalcType { get; set; }

    public decimal Amount { get; set; }

    public decimal SalCalcType { get; set; }

    public virtual T0050AdMaster Ad { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
