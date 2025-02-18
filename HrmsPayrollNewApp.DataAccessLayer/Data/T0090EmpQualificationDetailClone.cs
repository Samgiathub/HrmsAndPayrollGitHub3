using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpQualificationDetailClone
{
    public decimal EmpId { get; set; }

    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal QualId { get; set; }

    public string? Specialization { get; set; }

    public decimal? Year { get; set; }

    public string? Score { get; set; }

    public DateTime? StDate { get; set; }

    public DateTime? EndDate { get; set; }

    public string? Comments { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal LoginId { get; set; }
}
