using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewFilePendingApproveBackup160922
{
    public byte RptLevel { get; set; }

    public string? ApplicationStatus { get; set; }

    public decimal SchemeId { get; set; }

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

    public string? EmpFirstName { get; set; }

    public string? TypeTitle { get; set; }

    public string FileNumber { get; set; } = null!;

    public string? Subject { get; set; }

    public string? Description { get; set; }

    public string? ProcessDate { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? CmpId { get; set; }

    public string? FileAppDoc { get; set; }

    public decimal? FTypeId { get; set; }

    public string? UserId { get; set; }

    public string Rcomments { get; set; } = null!;

    public decimal ReviewEmpId { get; set; }

    public string? Addedby { get; set; }

    public string? Updatedby { get; set; }

    public string ForwardEmployee { get; set; } = null!;

    public string FileTypeNumber { get; set; } = null!;
}
