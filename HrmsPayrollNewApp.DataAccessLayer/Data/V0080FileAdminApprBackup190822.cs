using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080FileAdminApprBackup190822
{
    public int? FaId { get; set; }

    public string? Id { get; set; }

    public decimal FileAprId { get; set; }

    public int? FileAppId { get; set; }

    public decimal? EmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? ReportingManager { get; set; }

    public string? ApplicationDate { get; set; }

    public string? BranchName { get; set; }

    public string? DeptName { get; set; }

    public string? DesigName { get; set; }

    public int? FStatusId { get; set; }

    public string? Status { get; set; }

    public string? TypeTitle { get; set; }

    public string FileNumber { get; set; } = null!;

    public string? Subject { get; set; }

    public string? Description { get; set; }

    public string? ProcessDate { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? CmpId { get; set; }

    public string? FileAppDoc { get; set; }

    public decimal? FTypeId { get; set; }

    public decimal ForwardEmpId { get; set; }

    public decimal SubmitEmpId { get; set; }

    public string? ApproveDate { get; set; }

    public string? LoginName { get; set; }

    public string ApprovalComments { get; set; } = null!;

    public decimal ReviewEmpId { get; set; }

    public decimal ReviewedByEmpId { get; set; }

    public string ForwardEmployee { get; set; } = null!;
}
