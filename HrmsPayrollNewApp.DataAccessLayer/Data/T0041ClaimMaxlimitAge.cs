using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0041ClaimMaxlimitAge
{
    public int AgeId { get; set; }

    public int? ClaimId { get; set; }

    public double? AgeMin { get; set; }

    public double? AgeMax { get; set; }

    public double? AgeAmount { get; set; }

    public int? GradeId { get; set; }
}
