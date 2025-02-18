using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090CurrentManagerDetail
{
    public string? EmployeeCode { get; set; }

    public string? EmployeeName { get; set; }

    public string? BranchName { get; set; }

    public string? DateOfJoin { get; set; }

    public string ManagerDesignation { get; set; } = null!;

    public string? ManagerName { get; set; }

    public string ManagerCompany { get; set; } = null!;

    public string ReportingMethod { get; set; } = null!;

    public string? EffectDate { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal BranchId { get; set; }
}
