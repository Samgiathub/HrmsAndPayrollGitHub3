using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsEmployeeQuestion
{
    public string? Question { get; set; }

    public string? QueDescription { get; set; }

    public decimal EmpInspectionId { get; set; }

    public int? InspectionStatus { get; set; }

    public int? QueRate { get; set; }

    public string? Answer { get; set; }

    public DateTime? ForDate { get; set; }

    public int? EmpStatus { get; set; }

    public decimal ApprId { get; set; }

    public decimal EmpId { get; set; }

    public decimal QueId { get; set; }

    public decimal ApprDetailId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal ApprIntId { get; set; }
}
