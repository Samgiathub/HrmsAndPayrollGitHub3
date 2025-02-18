using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050TrainingLocationMaster
{
    public decimal TrainingInstituteLocId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TrainingInstituteId { get; set; }

    public string InstituteLocationCode { get; set; } = null!;

    public string? InstituteLocationDesc { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0050HrmsTrainingProviderMaster> T0050HrmsTrainingProviderMasters { get; set; } = new List<T0050HrmsTrainingProviderMaster>();

    public virtual ICollection<T0055TrainingFaculty> T0055TrainingFaculties { get; set; } = new List<T0055TrainingFaculty>();

    public virtual T0050TrainingInstituteMaster TrainingInstitute { get; set; } = null!;
}
