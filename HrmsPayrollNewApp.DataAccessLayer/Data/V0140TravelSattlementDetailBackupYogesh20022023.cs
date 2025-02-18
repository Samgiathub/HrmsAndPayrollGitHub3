using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140TravelSattlementDetailBackupYogesh20022023
{
    public decimal TravelApprovalId { get; set; }

    public DateTime ApprovalDate { get; set; }

    public string? ApprovalComments { get; set; }

    public string ApprovalStatus { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? TravelApplicationId { get; set; }

    public decimal Total { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? SEmpFullName { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal BranchId { get; set; }

    public DateTime FromDate { get; set; }

    public decimal? InstructEmpId { get; set; }

    public decimal Period { get; set; }

    public string PlaceOfVisit { get; set; } = null!;

    public string? Remarks { get; set; }

    public DateTime ToDate { get; set; }

    public decimal TravelApprovalDetailId { get; set; }

    public decimal TravelModeId { get; set; }

    public string TravelPurpose { get; set; } = null!;

    public string? TravelModeName { get; set; }

    public decimal StateId { get; set; }

    public decimal CityId { get; set; }

    public string? City { get; set; }

    public string? State { get; set; }

    public string? TravelAppCode { get; set; }

    public string? LocName { get; set; }

    public decimal LocId { get; set; }

    public string? TourAgenda { get; set; }

    public string? ImpBusinessAppoint { get; set; }

    public string? KraTour { get; set; }

    public string? TravelTypeName { get; set; }

    public decimal TravelTypeId { get; set; }
}
