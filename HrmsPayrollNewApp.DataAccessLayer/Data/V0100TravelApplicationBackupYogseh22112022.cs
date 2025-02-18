using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100TravelApplicationBackupYogseh22112022
{
    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal TravelApplicationId { get; set; }

    public string ApplicationCode { get; set; } = null!;

    public DateTime ApplicationDate { get; set; }

    public string? EmpFullName { get; set; }

    public string? Supervisor { get; set; }

    public string ApplicationStatus { get; set; } = null!;

    public string DesigName { get; set; } = null!;

    public string? BranchName { get; set; }

    public decimal BranchId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal TravelApprovalId { get; set; }

    public decimal TravelSetApplicationId { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? ApplicationDateShow { get; set; }

    public int Cnt { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public string? EmpVisit { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? DynHierColValue { get; set; }

    public decimal TravelTypeId { get; set; }

    public string? TravelTypeName { get; set; }

    public int? ProofCount { get; set; }
}
