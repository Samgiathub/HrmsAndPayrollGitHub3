using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080GrieAppForm
{
    public int GrievanceId { get; set; }

    public int? TypeOfGrieId { get; set; }

    public DateTime? DateOfGrievance { get; set; }

    public int? GrieAgainstId { get; set; }

    public string? GrievanceDesc { get; set; }

    public int? IsActive { get; set; }

    public int? CmpId { get; set; }
}
