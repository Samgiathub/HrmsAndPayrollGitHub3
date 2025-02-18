using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050Form16Import
{
    public decimal FormId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? FinancialYear { get; set; }

    public string? ReportPartA { get; set; }

    public string? ReportPartB { get; set; }

    public string? UploadedBy { get; set; }

    public DateTime? UploadedOn { get; set; }
}
