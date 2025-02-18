using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0045HrmsRProcessTemplate
{
    public string? ProcessName { get; set; }

    public decimal ProcessQId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ProcessId { get; set; }

    public string? QueDetail { get; set; }

    public string IsTitle { get; set; } = null!;

    public string IsDescription { get; set; } = null!;

    public string IsRaiting { get; set; } = null!;

    public string IsDynamic { get; set; } = null!;

    public int? DisNo { get; set; }

    public string QuestionType { get; set; } = null!;

    public string? QuestionOption { get; set; }

    public int? QuestionType1 { get; set; }
}
