using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class GetProjectDetail
{
    public decimal ProjectId { get; set; }

    public string? ProjectName { get; set; }

    public string? ProjectCode { get; set; }

    public DateTime? StartDate { get; set; }

    public string? Duration { get; set; }

    public DateTime? DueDate { get; set; }

    public string? ProjectDescription { get; set; }

    public decimal ProjectStatusId { get; set; }

    public decimal ClientId { get; set; }

    public string? TimeSheetApprovalType { get; set; }

    public decimal? ProjectCost { get; set; }

    public string? Attachment { get; set; }

    public int? Completed { get; set; }

    public int? Disabled { get; set; }

    public string? Address1 { get; set; }

    public string? Address2 { get; set; }

    public decimal LocId { get; set; }

    public decimal? StateId { get; set; }

    public string? Zipcode { get; set; }

    public int OverheadCalculation { get; set; }

    public string? PhoneNo { get; set; }

    public string? FaxNo { get; set; }

    public string? ContactPerson { get; set; }

    public string? ContactEmail { get; set; }

    public decimal? SpecialityId { get; set; }

    public string? SpecialityName { get; set; }

    public string? ContractType { get; set; }

    public decimal? FedoraCharges { get; set; }

    public decimal? AssignTo { get; set; }

    public decimal ProjectDetailId { get; set; }

    public decimal? CmpId { get; set; }

    public string? City { get; set; }

    public decimal BranchId { get; set; }

    public decimal? MbranchId { get; set; }
}
