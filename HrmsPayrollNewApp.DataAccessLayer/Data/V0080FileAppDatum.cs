using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080FileAppDatum
{
    public decimal FaId { get; set; }

    public string? Id { get; set; }

    public int FileAprId { get; set; }

    public decimal FileAppId { get; set; }

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

    public string Description { get; set; } = null!;

    public string? ProcessDate { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? CmpId { get; set; }

    public string? FileAppDoc { get; set; }

    public decimal? FTypeId { get; set; }

    public int ForwardEmpId { get; set; }

    public int SubmitEmpId { get; set; }

    public int ReviewEmpId { get; set; }

    public int ReviewedByEmpId { get; set; }

    public string? ApproveDate { get; set; }

    public string ApprovalComments { get; set; } = null!;

    public string ForwardedBy { get; set; } = null!;

    public string UpdatedBy { get; set; } = null!;

    public string? Applicant { get; set; }

    public string? LoginName { get; set; }

    public decimal? EId { get; set; }

    public string? ApplicationBy { get; set; }

    public decimal SchemeId { get; set; }

    public byte RptLevel { get; set; }

    public string FileTypeNumber { get; set; } = null!;
}
