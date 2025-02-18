using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ActiveInActiveUsersMobile
{
    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string? EmpFullName { get; set; }

    public string? DeptName { get; set; }

    public string? DesigName { get; set; }

    public string Gender { get; set; } = null!;

    public string? BranchName { get; set; }

    public string? EmpLeft { get; set; }

    public byte IsForMobileAccess { get; set; }

    public string LoginName { get; set; } = null!;

    public byte IsActive { get; set; }

    public DateTime? EmpLeftDate { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string EmpSecondName { get; set; } = null!;

    public string EmpLastName { get; set; } = null!;

    public string? AlphaEmpCode { get; set; }

    public string? GrdName { get; set; }

    public decimal EmpCode { get; set; }
}
