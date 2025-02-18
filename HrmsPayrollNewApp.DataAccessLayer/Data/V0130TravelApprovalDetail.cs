using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0130TravelApprovalDetail
{
    public decimal TravelApprovalId { get; set; }

    public DateTime ApprovalDate { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? SEmpId { get; set; }

    public string? Supervisor { get; set; }

    public decimal TravelApprovalDetailId { get; set; }

    public string PlaceOfVisit { get; set; } = null!;

    public string TravelPurpose { get; set; } = null!;

    public decimal? InstructEmpId { get; set; }

    public string? InstructEmpName { get; set; }

    public decimal TravelModeId { get; set; }

    public string TravelModeName { get; set; } = null!;

    public DateTime FromDate { get; set; }

    public decimal Period { get; set; }

    public DateTime ToDate { get; set; }

    public string? Remarks { get; set; }
}
