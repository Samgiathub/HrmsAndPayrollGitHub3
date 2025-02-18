using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040GrievanceTypeMaster
{
    public int GrievanceTypeId { get; set; }

    public string? GrievanceTypeCode { get; set; }

    public string? GrievanceTypeTitle { get; set; }

    public string? GrievanceTypeStatus { get; set; }

    public DateTime? GrievanceTypeCdtm { get; set; }

    public DateTime? GrievanceTypeUdtm { get; set; }

    public string? GrievanceTypeLog { get; set; }

    public int? IsActive { get; set; }

    public int? CmpId { get; set; }
}
