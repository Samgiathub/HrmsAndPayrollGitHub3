using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115WoApprovalMain
{
    public decimal WoApprovalId { get; set; }

    public decimal? WoApplicationId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime ApprovalDate { get; set; }

    public string? ApprovaStatus { get; set; }

    public decimal? LoginId { get; set; }

    public decimal? Month { get; set; }

    public decimal? Year { get; set; }
}
