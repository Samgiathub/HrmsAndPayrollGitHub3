using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110FacultyRatingDetail
{
    public decimal FacultyRatingId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TrainingAprId { get; set; }

    public decimal FacultyId { get; set; }

    public decimal Rating { get; set; }

    public string? Comments { get; set; }
}
