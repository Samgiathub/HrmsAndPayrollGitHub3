using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095EmpGeoLocationAssign
{
    public decimal EmpGeoLocationId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }
}
