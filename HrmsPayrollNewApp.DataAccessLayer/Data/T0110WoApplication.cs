using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110WoApplication
{
    public decimal WoApplicationId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public DateTime ApplicationDate { get; set; }

    public DateTime? WoDate { get; set; }

    public string? WoDay { get; set; }

    public string? NoOfDays { get; set; }

    public DateTime? NewWoDate { get; set; }

    public string? NewWoDay { get; set; }

    public string? Status { get; set; }

    public decimal? LoginId { get; set; }

    public decimal? Month { get; set; }

    public decimal? Year { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal SupEmpId { get; set; }
}
