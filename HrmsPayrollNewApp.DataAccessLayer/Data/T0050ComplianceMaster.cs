using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050ComplianceMaster
{
    public decimal ComplianceId { get; set; }

    public decimal CmpId { get; set; }

    public string ComplianceName { get; set; } = null!;

    public string ComplianceCode { get; set; } = null!;

    public byte ComplianceYearType { get; set; }

    public int? ComplianceSubmitionType { get; set; }

    public DateTime? UpdatedDate { get; set; }

    public byte ComplianceViewInDash { get; set; }

    public byte ComplianceViewInRepo { get; set; }

    public string DueDate { get; set; } = null!;

    public string? DueMonth { get; set; }

    public string? ToEmail { get; set; }

    public string? CcEmail { get; set; }
}
