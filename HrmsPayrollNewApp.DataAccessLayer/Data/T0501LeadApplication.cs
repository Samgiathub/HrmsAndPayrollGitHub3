using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0501LeadApplication
{
    public decimal LeadAppId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string? CustName { get; set; }

    public string? CustAddress { get; set; }

    public string? CustCity { get; set; }

    public string? CustState { get; set; }

    public decimal? CustPincode { get; set; }

    public decimal? CustMobile { get; set; }

    public string? CustEmail { get; set; }

    public string? CustPanno { get; set; }

    public string? BackOfficeCode { get; set; }

    public decimal? LeadTypeId { get; set; }

    public decimal? LeadProductId { get; set; }

    public decimal? VisitTypeId { get; set; }

    public DateTime? VisitDate { get; set; }

    public DateTime? FollowUpDate { get; set; }

    public string? FollowDateHistory { get; set; }

    public decimal? LeadStatusId { get; set; }

    public string? Remarks { get; set; }

    public decimal? CollectedAmt { get; set; }

    public DateTime? ModifyDate { get; set; }

    public string? ModifyBy { get; set; }

    public decimal? RegHeadId { get; set; }

    public decimal? AssignTo { get; set; }

    public DateTime? AssignDate { get; set; }

    public byte IsAssigned { get; set; }
}
