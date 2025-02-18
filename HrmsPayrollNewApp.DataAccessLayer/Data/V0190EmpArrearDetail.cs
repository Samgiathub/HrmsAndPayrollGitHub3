using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0190EmpArrearDetail
{
    public decimal ArrearId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal ForMonth1 { get; set; }

    public string? ForMonth { get; set; }

    public decimal ForYear { get; set; }

    public decimal Days { get; set; }

    public decimal? EffectiveMonth1 { get; set; }

    public string? EffectiveMonth { get; set; }

    public decimal? EffectiveYear { get; set; }

    public string LeaveName { get; set; } = null!;

    public string? Remarks { get; set; }
}
