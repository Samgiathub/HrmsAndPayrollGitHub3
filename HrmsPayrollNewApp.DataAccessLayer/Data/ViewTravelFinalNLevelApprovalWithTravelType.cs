using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewTravelFinalNLevelApprovalWithTravelType
{
    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public string? Supervisor { get; set; }

    public decimal TravelApplicationId { get; set; }

    public string ApplicationCode { get; set; } = null!;

    public string? BranchName { get; set; }

    public string DesigName { get; set; } = null!;

    public string? AlphaEmpCode { get; set; }

    public DateTime ApplicationDate { get; set; }

    public string ApplicationStatus1 { get; set; } = null!;

    public string ApplicationStatus { get; set; } = null!;

    public decimal TravelSetApplicationId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal BranchId { get; set; }

    public decimal? SEmpIdA { get; set; }

    public string? EmpVisit { get; set; }
}
