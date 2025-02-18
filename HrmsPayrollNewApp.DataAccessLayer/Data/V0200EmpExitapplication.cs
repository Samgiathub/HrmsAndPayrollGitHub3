using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0200EmpExitapplication
{
    public decimal ExitId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal? DesigId { get; set; }

    public DateTime? ResignationDate { get; set; }

    public DateTime LastDate { get; set; }

    public decimal? Reason { get; set; }

    public string? Comments { get; set; }

    public string Status { get; set; } = null!;

    public decimal? IsRehirable { get; set; }

    public decimal SEmpId { get; set; }

    public string EmpSuperior { get; set; } = null!;

    public string? Feedback { get; set; }

    public string? SupAck { get; set; }

    public DateTime? InterviewDate { get; set; }

    public decimal? RptMngId { get; set; }

    public string? InterviewTime { get; set; }

    public string IsProcess { get; set; } = null!;

    public string? EmailForwardTo { get; set; }

    public string? DriveDataForwardTo { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public DateTime? ApplicationDate { get; set; }

    public DateTime ApprovalDate { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public string? BranchName { get; set; }

    public string DesigName { get; set; } = null!;

    public string? ExitAppDoc { get; set; }
}
