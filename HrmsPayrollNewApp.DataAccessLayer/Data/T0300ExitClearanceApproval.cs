using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0300ExitClearanceApproval
{
    public decimal ApprovalId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime RequestDate { get; set; }

    public DateTime? ApprovalDate { get; set; }

    public decimal EmpId { get; set; }

    public decimal ExitId { get; set; }

    public decimal HodId { get; set; }

    public string NocStatus { get; set; } = null!;

    public string? Remarks { get; set; }

    public DateTime? SysDate { get; set; }

    public decimal? DeptId { get; set; }

    public decimal UpdatedBy { get; set; }

    public decimal? CenterId { get; set; }
}
