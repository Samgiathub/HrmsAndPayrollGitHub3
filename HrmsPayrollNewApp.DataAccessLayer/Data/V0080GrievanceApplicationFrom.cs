using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080GrievanceApplicationFrom
{
    public int GrievanceId { get; set; }

    public int? TypeOfGrieId { get; set; }

    public string? GrievanceTypeTitle { get; set; }

    public string? DateOfGrievance { get; set; }

    public int? GrieAgainstId { get; set; }

    public string? GrievanceDesc { get; set; }

    public int? CmpId { get; set; }
}
