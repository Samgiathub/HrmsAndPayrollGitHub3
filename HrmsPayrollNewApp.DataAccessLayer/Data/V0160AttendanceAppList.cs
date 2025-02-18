using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0160AttendanceAppList
{
    public decimal EmpId { get; set; }

    public DateTime? EffectDate { get; set; }

    public decimal? REmpId { get; set; }

    public decimal AttAppId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? ShiftSec { get; set; }

    public decimal? PDays { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public int AttAprId { get; set; }

    public string Status { get; set; } = null!;

    public string Remarks { get; set; } = null!;
}
