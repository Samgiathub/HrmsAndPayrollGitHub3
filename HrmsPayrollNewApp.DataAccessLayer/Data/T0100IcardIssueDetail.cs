using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100IcardIssueDetail
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal IncrementId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public string? Reason { get; set; }

    public bool IsRecovered { get; set; }

    public decimal IssueBy { get; set; }

    public DateTime IssueDate { get; set; }

    public DateTime? ReturnDate { get; set; }

    public DateTime? ExpiryDate { get; set; }
}
