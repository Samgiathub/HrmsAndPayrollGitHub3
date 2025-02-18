using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0190EmpArrearDetail
{
    public decimal ArrearId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal ForMonth { get; set; }

    public decimal ForYear { get; set; }

    public decimal Days { get; set; }

    public byte? LeaveAdjustment { get; set; }

    public decimal? EffectiveMonth { get; set; }

    public decimal? EffectiveYear { get; set; }

    public byte? IsAbsent { get; set; }

    public decimal? AdjustWithLeave { get; set; }

    public string? Remarks { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
