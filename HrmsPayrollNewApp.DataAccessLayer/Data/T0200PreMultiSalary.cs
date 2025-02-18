using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0200PreMultiSalary
{
    public decimal RowId { get; set; }

    public string? SalaryParameter { get; set; }

    public byte? IsManual { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? Id { get; set; }

    public byte? BackEndSalary { get; set; }

    public int? Processed { get; set; }

    public decimal? UserId { get; set; }

    public DateTime? Date { get; set; }

    public DateTime? StartTime { get; set; }

    public DateTime? EndTime { get; set; }
}
