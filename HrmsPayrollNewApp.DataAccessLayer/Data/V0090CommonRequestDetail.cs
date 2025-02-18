using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090CommonRequestDetail
{
    public string? DomainName { get; set; }

    public decimal RequestId { get; set; }

    public decimal? CmpId { get; set; }

    public string? RequestType { get; set; }

    public DateTime? RequestDate { get; set; }

    public string? RequestDetail { get; set; }

    public int Status { get; set; }

    public decimal? LoginId { get; set; }

    public string? FeedbackDetail { get; set; }

    public decimal? EmpLoginId { get; set; }

    public string? DomainName1 { get; set; }

    public string RequestStatus { get; set; } = null!;

    public string? LoginName1 { get; set; }

    public string? EmpFirstName1 { get; set; }

    public string? EmpName1 { get; set; }

    public string? LoginName { get; set; }

    public string? EmpFirstName { get; set; }

    public string? EmpName { get; set; }

    public string? EmpLeft { get; set; }
}
