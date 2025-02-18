using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100WoApplicationMain
{
    public decimal WoApplicationId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime ApplicationDate { get; set; }

    public string? ApplicationStatus { get; set; }

    public decimal? LoginId { get; set; }

    public decimal? Month { get; set; }

    public decimal? Year { get; set; }
}
