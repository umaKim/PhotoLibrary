# PhotoLibrary


## 앱 구조
<img width="1127" alt="스크린샷 2023-11-01 오전 10 15 50" src="https://github.com/umaKim/PhotoLibrary/assets/85341050/228270db-8546-4882-b7d5-d8f98d00e784">


Repository에서 디바이스로부터 모든 이미지를 받아와서 ViewModel로 넘겨 줍니다.
ViewModel은 화면 상태와 관련된 business logic의 책임을 담당합니다.
Business Logic으로는 한 row에 몇개의 column 사진들이 보여야하는지, PHCachingImageManager로 PHAsset의 이미지들을 어떻게 UIImage로 만들어오는지 등을 담당하게 하였습니다. 이러한 과정들은 어떻게 수많은 유저의 이미지들을 메모리 이슈 없이 가져올지를 위해 고안된것입니다. 이런식으로 책임 분리가 명확하게 해서 유지보수를 유리하게 했습니다.


## 시연 영상

#### 3, 4, 5로 변경 기능

![RPReplay_Final1698765899](https://github.com/umaKim/PhotoLibrary/assets/85341050/e1b1dacf-46b7-44d0-98d1-290df29c5d55)

<br/>

#### 사진을 누르면 해당 사진이 보이는 기능

![RPReplay_Final1698766147 (1)](https://github.com/umaKim/PhotoLibrary/assets/85341050/988b9999-d9a0-4a32-8836-523a4fbd427f)

<br/>

#### 유저의 모든 이미지들을 불러오고 스크롤 해도 메모리에 이슈가 없습니다.
![RPReplay_Final1698767102](https://github.com/umaKim/PhotoLibrary/assets/85341050/0a5b954d-b150-4f21-86e7-fe09e32942d1)


