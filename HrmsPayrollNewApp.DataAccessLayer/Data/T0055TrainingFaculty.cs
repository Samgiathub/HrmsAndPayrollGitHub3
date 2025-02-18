using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055TrainingFaculty
{
    public decimal TrainingFacultyId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TrainingInstituteId { get; set; }

    public string FacultyName { get; set; } = null!;

    public string? FacultyContact { get; set; }

    public bool? Active { get; set; }

    public decimal? TrainingInstituteLocId { get; set; }

    public decimal? TrainingId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040HrmsTrainingMaster? Training { get; set; }

    public virtual T0050TrainingInstituteMaster TrainingInstitute { get; set; } = null!;

    public virtual T0050TrainingLocationMaster? TrainingInstituteLoc { get; set; }
}
