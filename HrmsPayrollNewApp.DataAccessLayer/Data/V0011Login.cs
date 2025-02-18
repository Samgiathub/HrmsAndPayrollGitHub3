using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0011Login
{
    public string LoginName { get; set; } = null!;

    public string LoginPassword { get; set; } = null!;

    public decimal LoginId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? EmpId { get; set; }

    public string? EmpFirstName { get; set; }

    public string? EmpLastName { get; set; }

    public string? EmpFullName { get; set; }

    public string? OtherEmail { get; set; }

    public string? WorkEmail { get; set; }

    public string? DeptName { get; set; }

    public string? BranchName { get; set; }

    public string? DesigName { get; set; }

    public string? GrdName { get; set; }

    public string? EmpFullNameNew { get; set; }

    public string? EmpCode { get; set; }

    public decimal? IsDefault { get; set; }

    public string? HrEmailId { get; set; }

    public string? AccEmailId { get; set; }

    public decimal? EmpSuperior { get; set; }

    public string? AlphaEmpCode { get; set; }

    public byte? IsHr { get; set; }

    public byte? IsAccou { get; set; }

    public string? EmpLeft { get; set; }

    public string LoginAlias { get; set; } = null!;

    public decimal IsIt { get; set; }

    public byte? TravelHelpDesk { get; set; }

    public string? MobileNo { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? EmpBranch { get; set; }
}
