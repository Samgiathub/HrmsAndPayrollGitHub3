using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0110CompoffApplicationDetail
{
    public decimal CmpId { get; set; }

    public DateTime ExtraWorkDate { get; set; }

    public string ExtraWorkHours { get; set; } = null!;

    public string ExtraWorkReason { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDatetime { get; set; }

    public decimal CompoffAppId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime ApplicationDate { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? EmpSuperior { get; set; }

    public string? SeniorEmployee { get; set; }

    public string ApplicationStatus { get; set; } = null!;

    public string? EmpFirstName { get; set; }

    public string? SEmpFirstName { get; set; }

    public string? EmpLeft { get; set; }

    public string? SOtherEmail { get; set; }

    public string? MobileNo { get; set; }

    public decimal? GrdId { get; set; }

    public DateTime? DateOfJoin { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public string? SEmpFullName { get; set; }

    public string? OtherEmail { get; set; }

    public decimal? BranchId { get; set; }

    public string? DesigName { get; set; }

    public decimal? SEmpCode { get; set; }

    public string? BranchName { get; set; }

    public decimal? EmpCode { get; set; }

    public string? WorkEmail { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? CompOffType { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public byte OtType { get; set; }

    public string? SanctionedHours { get; set; }

    public string? ApproveComments { get; set; }
}
