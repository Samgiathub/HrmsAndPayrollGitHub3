using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0165AttendanceApproval
{
    public decimal AttAprId { get; set; }

    public decimal? AttAppId { get; set; }

    public decimal? EmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? PDays { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? Remarks { get; set; }

    public decimal? ShiftSec { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? ApproverEmpId { get; set; }

    public string? Status { get; set; }
}
