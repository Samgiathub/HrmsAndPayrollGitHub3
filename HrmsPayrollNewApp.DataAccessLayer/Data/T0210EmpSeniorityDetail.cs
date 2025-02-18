using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0210EmpSeniorityDetail
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal AdId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal CalculationAmount { get; set; }

    public decimal Period { get; set; }

    public string Mode { get; set; } = null!;

    public decimal? Amount { get; set; }

    public decimal? NetAmount { get; set; }

    public string? Remarks { get; set; }

    public DateTime? ModifyDate { get; set; }
}
