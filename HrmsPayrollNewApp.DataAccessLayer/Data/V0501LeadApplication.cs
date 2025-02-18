using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0501LeadApplication
{
    public decimal LeadAppId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string AssignedToName { get; set; } = null!;

    public string CustName { get; set; } = null!;

    public string CustAddress { get; set; } = null!;

    public string CustCity { get; set; } = null!;

    public string CustState { get; set; } = null!;

    public decimal CustPincode { get; set; }

    public decimal CustMobile { get; set; }

    public string CustEmail { get; set; } = null!;

    public string CustPanno { get; set; } = null!;

    public string BackOfficeCode { get; set; } = null!;

    public decimal LeadTypeId { get; set; }

    public string LeadTypeName { get; set; } = null!;

    public decimal LeadProductId { get; set; }

    public string LeadProductName { get; set; } = null!;

    public decimal VisitTypeId { get; set; }

    public string VisitTypeName { get; set; } = null!;

    public decimal LeadStatusId { get; set; }

    public string LeadStatusName { get; set; } = null!;

    public string? VisitDate { get; set; }

    public string? FollowUpDate { get; set; }

    public string FollowDateHistory { get; set; } = null!;

    public string Remarks { get; set; } = null!;

    public decimal CollectedAmt { get; set; }

    public string? ModifyDate { get; set; }

    public string ModifyBy { get; set; } = null!;

    public decimal AssignTo { get; set; }

    public decimal RegHeadId { get; set; }

    public string? AssignDate { get; set; }
}
