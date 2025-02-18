using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsEmployeeIntrospection
{
    public decimal EmpInspectionId { get; set; }

    public decimal ApprDetailId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal QueId { get; set; }

    public string? Answer { get; set; }

    public int? EmpStatus { get; set; }

    public int? InspectionStatus { get; set; }

    public int? QueRate { get; set; }

    public decimal? CmpId { get; set; }

    public virtual T0090HrmsAppraisalInitiationDetail ApprDetail { get; set; } = null!;

    public virtual T0055HrmsApprFeedbackQuestion Que { get; set; } = null!;
}
